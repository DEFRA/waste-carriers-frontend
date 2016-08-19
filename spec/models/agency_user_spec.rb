require 'spec_helper'

describe AgencyUser, type: :model do
  describe 'password field' do
    it_behaves_like 'password with strength restrictions'
  end
end
