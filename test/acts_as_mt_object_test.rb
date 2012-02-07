require 'test_helper'

class ActsAsMtObjectTest < ActiveSupport::TestCase
  test "module loaded" do
    assert_kind_of Module, ActsAsMtObject
  end

  @@entry_data = {
    4 => {
      :id               => 4,
      :title            => '1st entry title',
      :text             => '1st entry body',
      :current_revision => 1,
      :price            => 'unknown',  # default
      :deadline_date    => '',         # default
    },
    5 => {
      :id               => 5,
      :title            => '2nd entry title',
      :text             => '2nd entry body',
      :current_revision => 1,
      :price            => '30000',
      :deadline_date    => DateTime.parse('2012-02-01 10:10:00 UTC'),
    }
  }

  [Plan, MT::Entry].each do |klass|
    test klass.to_s do
      for id, data in @@entry_data 
        entry = klass.find(id)
        assert_not_nil(entry)
        for key, value in data
          assert_equal entry.send(key), value
        end
      end
    end
  end
end
