require 'rake/clean'

EYAML_FILES = FileList['kubernetes/**/*.eyaml']
CLEAN.include(EYAML_FILES.ext('.yaml'))

rule '.yaml' => '.eyaml' do |t|
  puts "#{t.name} #{t.source}"
  sh "eyaml decrypt -f #{t.source} > #{t.name}"
end

namespace :eyaml do
  desc 'generate new eyaml keys'
  task :createkeys do |t|
    sh "eyaml #{t}"
  end

  desc 'setup default sqre keyring'
  task :sqre do |t|
    sh <<-EOS
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
    sh <<-EOS
      cd terraform
      make
    EOS
  end

  desc 'write s3sync secrets data from tf state'
  task :s3sync do
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
        'name' => 's3sync-secret'
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
end

task :default => [
  :terraform,
  'eyaml:decrypt',
]
