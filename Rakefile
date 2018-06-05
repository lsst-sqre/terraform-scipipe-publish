require 'rake/clean'

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

def b64(text)
  # Base64.encode64 will append unwanted newlines
  Base64.encode64(text).strip!
end

class TFOutput
  class << self
    def eyaml_block(text)
      "DEC::PKCS7[#{text}]!"
    end
  end

  def initialize(path:, eyamlize: false, base64: false)
    Dir.chdir(path) do
      @output = JSON.parse(`../bin/terraform output -json`)
    end
    @base64   = base64
    @eyamlize = eyamlize
  end

  def [](k)
    v = @output[k] ? @output[k]['value'] : nil
    return if v.nil?
    if @base64
      v = b64(v)
    end
    # only add eyaml block armor to variables tf has indicated are 'sensitive'
    if @eyamlize and @output[k]['sensitive']
      v = self.class.eyaml_block(v)
    end
    v
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

      out = TFOutput.new(path: 'terraform/s3', base64: true)

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
        'AWS_ACCESS_KEY_ID'     => out['EUPS_PULL_AWS_ACCESS_KEY_ID'],
        'AWS_SECRET_ACCESS_KEY' => out['EUPS_PULL_AWS_SECRET_ACCESS_KEY'],
        'S3_BUCKET'             => out['EUPS_S3_BUCKET'],
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

namespace :jenkins do
  desc 'print jenkins hiera yaml'
  task 'creds' do
    require 'yaml'
    require 'json'

    s3_out  = TFOutput.new(path: 'terraform/s3', eyamlize: true)
    dox_out = TFOutput.new(path: 'terraform/doxygen', eyamlize: true)

    creds = {
      'aws-eups-push' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'push EUPS packages -> s3',
        'username'    => s3_out['EUPS_PUSH_AWS_ACCESS_KEY_ID'],
        'password'    => s3_out['EUPS_PUSH_AWS_SECRET_ACCESS_KEY'],
      },
      'eups-push-bucket' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'StringCredentialsImpl',
        'description' => 'name of EUPS s3 bucket',
        'secret'      => s3_out['EUPS_S3_BUCKET'],
      },
      'aws-eups-backup' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'backup EUPS s3 bucket -> s3 bucket',
        'username'    => s3_out['EUPS_BACKUP_AWS_ACCESS_KEY_ID'],
        'password'    => s3_out['EUPS_BACKUP_AWS_SECRET_ACCESS_KEY'],
      },
      'eups-backup-bucket' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'StringCredentialsImpl',
        'description' => 'name of EUPS backup s3 bucket',
        'secret'      => s3_out['EUPS_BACKUP_S3_BUCKET'],
      },
      'aws-eups-tag-admin' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'manage eups distrib tags in s3 bucket',
        'username'    => s3_out['EUPS_TAG_ADMIN_AWS_ACCESS_KEY_ID'],
        'password'    => s3_out['EUPS_TAG_ADMIN_AWS_SECRET_ACCESS_KEY'],
      },
      'aws-doxygen-push' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'push doxygen builds -> s3',
        'username'    => dox_out['DOXYGEN_PUSH_AWS_ACCESS_KEY_ID'],
        'password'    => dox_out['DOXYGEN_PUSH_AWS_SECRET_ACCESS_KEY'],
      },
      'doxygen-push-bucket' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'StringCredentialsImpl',
        'description' => 'name of doxygen s3 bucket',
        'secret'      => dox_out['DOXYGEN_S3_BUCKET'],
      },
    }
    puts YAML.dump(creds)
  end
end

desc 'write creds.sh'
task :creds do
  File.write('creds.sh', <<-EOS.gsub(/^\s+/, '')
    # shellcheck shell=bash
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
]

desc 'destroy all tf/kube resources'
task :destroy => [
  'khelper:delete',
  'terraform:dns:destroy',
  'terraform:s3:destroy',
  'terraform:doxygen:destroy',
]
