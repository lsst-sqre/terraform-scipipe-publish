require 'rake/clean'

EYAML_FILES = FileList['kubernetes/**/*.eyaml']
CLEAN.include(EYAML_FILES.ext('.yaml'))

rule '.yaml' => '.eyaml' do |t|
  puts "#{t.name} #{t.source}"
  sh "eyaml decrypt -f #{t.source} > #{t.name}"
end

def sh_quiet(script)
  sh script do |ok, res|
    unless ok
      # exit without verbose rake error message
      exit res.exitstatus
    end
  end
end

def tf_cmd(env, name, arg)
  task name do
    sh_quiet <<-EOS
      cd terraform/#{env}
      ../bin/terraform #{arg}
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
  desc 'download terraform'
  task :install do
    sh_quiet <<-EOS
      cd terraform
      make
    EOS
  end

  namespace :s3 do
    env = 's3'

    desc 'apply'
    tf_cmd(env, :apply, 'apply')
    desc 'destroy'
    tf_cmd(env, :destroy, 'destroy -force')

    desc 'write s3sync secrets data from tf state'
    task 's3sync-secret' do
      require 'json'
      require 'yaml'
      require 'base64'

      ABS_PATH = File.expand_path(File.dirname(__FILE__))
      TF_STATE= "#{ABS_PATH}/terraform/s3/terraform.tfstate"

      fail "missing terraform state file: #{TF_STATE}" unless File.exist? TF_STATE
      outputs = JSON.parse(File.read(TF_STATE))["modules"].first["outputs"]
      outputs = case outputs.first[1]
      when Array
        # tf ~ 0.6
        outputs.map {|k,v| [k, v]}.to_h
      when Hash
        # tf >= 0.8 ?
        outputs.map {|k,v| [k, v['value']]}.to_h
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
          Base64.encode64(outputs['EUPS_PULL_AWS_ACCESS_KEY_ID']),
        'AWS_SECRET_ACCESS_KEY' =>
          Base64.encode64(outputs['EUPS_PULL_AWS_SECRET_ACCESS_KEY']),
        'S3_BUCKET' =>
          Base64.encode64(outputs['EUPS_S3_BUCKET']),
      }

      doc = YAML.dump secrets
      puts doc
      File.write('./kubernetes/s3sync-secret.yaml', doc)
    end
  end # :s3

  namespace :dns do
    env = 'dns'

    desc 'apply'
    tf_cmd(env, :apply, 'apply')
    desc 'destroy'
    tf_cmd(env, :destroy, 'destroy -force')
  end # :dns
end

namespace :gcloud do
  desc 'create gce storage disk'
  task :disk do
    sh_quiet <<-EOS
      gcloud compute disks create --size 1024GB eups-disk
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

  desc 'write service_ip.txt'
  khelper_cmd 'ip'

  desc 'delete kubernetes resources'
  khelper_cmd 'delete'
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
]
