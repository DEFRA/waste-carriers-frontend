require 'spec_helper'

describe Admin do
  describe 'password field' do
    it_behaves_like 'password with strength restrictions'
  end
end
