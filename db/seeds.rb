status_list = ['newcomer', 'user', 'fiduciary', 'VIP']
status_list.each do |status|
  UserStatus.create( name: status )
end
