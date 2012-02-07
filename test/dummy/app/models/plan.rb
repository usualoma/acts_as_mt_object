class Plan < ActiveRecord::Base
  establish_connection (::Rails.env + '_mt').to_sym
  acts_as_mt_object :mt_class => :Entry
end
