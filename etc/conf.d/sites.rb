if File.directory? BASE_DIR + '/etc/sites.d'
  Dir.foreach BASE_DIR + '/etc/sites.d' do | file |
    if not File.directory? BASE_DIR + '/etc/sites.d/' + file and file =~ /.*\.rb$/
      include_conf BASE_DIR + '/etc/sites.d/' + file, conf
    end
  end
end
