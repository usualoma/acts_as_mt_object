module MT
  class Entry < ActiveRecord::Base
    establish_connection (::Rails.env + '_mt').to_sym
    acts_as_mt_object
  end
end
