#proxies all 'db' class of OpenERP server/bin/service/web_service.py properly
module DbService
  def create(password=@config[:db_password], db_name='ooor_db', demo=true, lang='en-US', user_password=@config[:password] || 'admin')
    process_id = OpenObjectResource.try_with_pretty_error_log { OpenObjectResource.client(@base_url + "/db").call("create", password, db_name, demo, lang, user_password) }
    @config[:database] = db_name
    @config[:username] = user_password
    while get_progress('admin', process_id) == [0, []]
      @logger.info "..."
      sleep(0.5)
    end
    load_models()
  end

  def drop(password=@config[:db_password], db_name='ooor_db')
    OpenObjectResource.try_with_pretty_error_log { OpenObjectResource.client(@base_url + "/db").call("drop", password, db_name) }
  end

  #we generate methods handles for use in auto-completion tools such as jirb_swing
  [:get_progress, :dump, :restore, :rename, :db_exist, :list, :change_admin_password, :list_lang, :server_version, :migrate_databases].each do |meth|
    self.instance_eval do
      define_method meth do |*args|
        OpenObjectResource.try_with_pretty_error_log { OpenObjectResource.client(@base_url + "/db").call(meth.to_s, *args) }
      end
    end
  end
end