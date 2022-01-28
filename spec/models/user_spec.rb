# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string
#  first_name      :string
#  last_name       :string
#  password_digest :string
#  bio             :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should validate_presence_of(:username) }
  it { should validate_uniqueness_of(:username) }
  it { should validate_length_of(:username).is_at_least(2) }

  it { should validate_presence_of(:first_name) }
  it { should validate_length_of(:first_name).is_at_least(2) }

  it { should validate_presence_of(:last_name) }
  it { should validate_length_of(:last_name).is_at_least(2) }

  it { should validate_length_of(:bio).is_at_least(2) }

  it { should validate_presence_of(:password) }
  it { should validate_length_of(:password).is_at_least(8) }
end
