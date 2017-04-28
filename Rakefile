require 'rake/clean'

EYAML_FILES = FileList['kubernetes/**/*.eyaml']
CLEAN.include(EYAML_FILES.ext('.yaml'))

rule '.yaml' => '.eyaml' do |t|
  puts "#{t.name} #{t.source}"
  sh "eyaml decrypt -f #{t.source} > #{t.name}"
end

def gcloud_disk_size
  # in GiB
  '512'
end

def sh_quiet(script)
  sh script do |ok, res|
    unless ok
      # exit without verbose rake error message
      exit res.exitstatus
    end
  end
end

def tf_cmd(deploy, name, arg)
  task name do
    sh_quiet <<-EOS
      cd terraform/#{deploy}
      ../bin/terraform get
      ../bin/terraform #{arg}
    EOS
  end
end

def tf_bucket_region
  "us-west-2"
end

def env_prefix
  env = ENV['TF_VAR_env_name']

  if env.nil?
    abort('env var TF_VAR_env_name must be defined')
  end

  if env == 'prod'
    env = 'eups'
  else
    env = "#{env}-eups"
  end

  env
end

def tf_bucket
  "#{env_prefix}.lsst.codes-tf"
end

def tf_remote(deploy)
  desc 'configure remote state'

  task 'remote' do
    remote = 'init' +
      " -backend=true" +
      " -backend-config=\"region=#{tf_bucket_region}\"" +
      " -backend-config=\"bucket=#{tf_bucket}\"" +
      " -backend-config=\"key=#{deploy}/terraform.tfstate\"" +
      " -input=false" +
      " -get=true"

      sh_quiet <<-EOS
        cd terraform/#{deploy}
        ../bin/terraform #{remote}
      EOS
    end
end

namespace :eyaml do
  desc 'generate new eyaml keys'
  task :createkeys do |t|
    sh_quiet "eyaml #{t}"
  end

  desc 'setup default sqre keyring'
  task :sqre do |t|
    sh_quiet <<-EOS
      mkdir -p .lsst-certs
      cd .lsst-certs
      git init
      git remote add origin ~/Dropbox/lsst-sqre/git/lsst-certs.git
      git config core.sparseCheckout true
      echo "eyaml-keys/" >> .git/info/sparse-checkout
      git pull --depth=1 origin master
      cd ..
      ln -sf .lsst-certs/eyaml-keys keys
    EOS
  end

  desc 'decrypt all eyaml files (*.eyaml -> *.yaml'
  task :decrypt => EYAML_FILES.ext('.yaml')

  desc 'edit .eyaml file (requires keys)'
  task :edit, [:file] do |t, args|
    sh "eyaml edit #{args[:file]}"
    Rake::Task['eyaml:decrypt'].invoke
  end
end

namespace :terraform do
  namespace :bucket do
    desc 'create s3 bucket to hold remote state'
    task :create do
     sh_quiet "aws s3 mb s3://#{tf_bucket} --region #{tf_bucket_region}"
    end
  end

  desc 'download terraform'
  task :install do
    sh_quiet <<-EOS
      cd terraform
      make
    EOS
  end

  desc 'configure remote state on s3 bucket'
  task :remote => [
    'terraform:bucket:create',
    'terraform:dns:remote',
    'terraform:s3:remote',
    'terraform:doxygen:remote',
  ]

  namespace :s3 do
    deploy = 's3'

    desc 'apply'
    tf_cmd(deploy, :apply, 'apply')
    desc 'destroy'
    tf_cmd(deploy, :destroy, 'destroy -force')
    tf_remote(deploy)

    desc 'write s3sync secrets data from tf state'
    task 's3sync-secret' do
      require 'json'
      require 'yaml'
      require 'base64'

      outputs = nil
      Dir.chdir('terraform/s3') do
        outputs = JSON.parse(`../bin/terraform output -json`)
      end

      secrets = {
        'apiVersion' => 'v1',
        'kind'       => 'Secret',
        'metadata'   => {
          'name'   => 's3sync-secret',
          'labels' => {
            'name' => 's3sync-secret',
            'app'  => 'eups',
          },
        },
      }

      secrets['data'] = {
        'AWS_ACCESS_KEY_ID' =>
          Base64.encode64(outputs['EUPS_PULL_AWS_ACCESS_KEY_ID']['value']),
        'AWS_SECRET_ACCESS_KEY' =>
          Base64.encode64(outputs['EUPS_PULL_AWS_SECRET_ACCESS_KEY']['value']),
        'S3_BUCKET' =>
          Base64.encode64(outputs['EUPS_S3_BUCKET']['value']),
      }

      doc = YAML.dump secrets
      puts doc
      File.write('./kubernetes/s3sync-secret.yaml', doc)
    end
  end # :s3

  namespace :dns do
    deploy = 'dns'

    desc 'apply'
    tf_cmd(deploy, :apply, 'apply')
    desc 'destroy'
    tf_cmd(deploy, :destroy, 'destroy -force')
    tf_remote(deploy)
  end # :dns

  namespace :doxygen  do
    deploy = 'doxygen'

    desc 'apply'
    tf_cmd(deploy, :apply, 'apply')
    desc 'destroy'
    tf_cmd(deploy, :destroy, 'destroy -force')
    tf_remote(deploy)
  end # :doxygen
end

namespace :gcloud do
  desc 'create gce storage disk'
  task :disk do
    sh_quiet <<-EOS
      gcloud compute disks create --size #{gcloud_disk_size}GB #{env_prefix}-disk
    EOS
  end
end

def khelper_cmd(arg)
  task arg.to_sym do
    sh_quiet <<-EOS
      cd kubernetes
      ./khelper #{arg}
    EOS
  end
end

namespace :khelper do
  desc 'create kubeneretes resources'
  khelper_cmd 'create'

  desc 'apply kubeneretes resources'
  khelper_cmd 'apply'

  desc 'write service_ip.txt'
  khelper_cmd 'ip'

  desc 'delete kubernetes resources'
  khelper_cmd 'delete'
end

namespace :kube do
  desc 'write kubernetes PersistentVolume config'
  task 'write-pv' do
    require 'yaml'

    # https://kubernetes.io/docs/user-guide/persistent-volumes/#access-modes
    # https://kubernetes.io/docs/resources-reference/v1.5/#gcepersistentdiskvolumesource-v1
    pv = {
      'kind'       => 'PersistentVolume',
      'apiVersion' => 'v1',
      'metadata'   => {
        'name'        => 'eups-volume',
        'labels'      => {
          'name' => 'eups-volume',
          'app'  => 'eups',
        },
        # this may not be working, at least under 1.4.8
        'annotations' => {
          'pv.beta.kubernetes.io/gid'=>'4242',
        }
      },
      'spec'       => {
        'capacity'          => {
          'storage' => "#{gcloud_disk_size}Gi",
        },
        'accessModes'       => ['ReadWriteOnce'],
        'gcePersistentDisk' => {
          'pdName' => "#{env_prefix}-disk",
          'fsType' => 'ext4',
        }
      }
    }

    doc = YAML.dump pv
    puts doc
    File.write('./kubernetes/eups-pv.yaml', doc)

    pvc = {
      'kind' => 'PersistentVolumeClaim',
      'apiVersion' => 'v1',
      'metadata' => {
        'name' => 'eups-pvc',
        'labels' => {
          'name' => 'eups-pvc',
          'app' => 'eups',
        },
      },
      'spec' => {
        'accessModes' => [ 'ReadWriteOnce' ],
        'resources' => {
          'requests' => {
            'storage' => "#{gcloud_disk_size}Gi",
          },
        },
      },
    }

    doc = YAML.dump pvc
    puts doc
    File.write('./kubernetes/eups-pvc.yaml', doc)

  end
end

def tf_output(path)
  output = nil
  Dir.chdir(path) do
    output = JSON.parse(`../bin/terraform output -json`)
  end
  output
end

namespace :jenkins do
  desc 'print jenkins hiera yaml'
  task 'creds' do
    require 'yaml'
    require 'json'

    s3_output  = tf_output('terraform/s3')
    dox_output = tf_output('terraform/doxygen')

    creds = {
      'aws-eups-push' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'push EUPS packages -> s3',
        'username'    => s3_output['EUPS_PUSH_AWS_ACCESS_KEY_ID']['value'],
        'password'    => s3_output['EUPS_PUSH_AWS_SECRET_ACCESS_KEY']['value'],
      },
      'eups-push-bucket' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'StringCredentialsImpl',
        'description' => 'name of EUPS s3 bucket',
        'secret'      => s3_output['EUPS_S3_BUCKET']['value'],
      },
      'aws-doxygen-push' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'push doxygen builds -> s3',
        'username'    => dox_output['DOXYGEN_PUSH_AWS_ACCESS_KEY_ID']['value'],
        'password'    => dox_output['DOXYGEN_PUSH_AWS_SECRET_ACCESS_KEY']['value'],
      },
      'doxygen-push-bucket' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'StringCredentialsImpl',
        'description' => 'name of doxygen s3 bucket',
        'secret'      => dox_output['DOXYGEN_S3_BUCKET']['value'],
      },
    }
    puts YAML.dump(creds)
  end
end

desc 'write creds.sh'
task :creds do
  File.write('creds.sh', <<-EOS.gsub(/^\s+/, '')
    export AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']}
    export AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']}
    export AWS_DEFAULT_REGION=us-east-1
    export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
    export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
    export TF_VAR_aws_default_region=$AWS_DEFAULT_REGION
    export TF_VAR_env_name=#{ENV['USER']}-dev
    EOS
  )
end

task :default => [
  'terraform:install',
  'eyaml:decrypt',
]

desc 'destroy all tf/kube resources'
task :destroy => [
  'khelper:delete',
  'terraform:dns:destroy',
  'terraform:s3:destroy',
  'terraform:doxygen:destroy',
]
