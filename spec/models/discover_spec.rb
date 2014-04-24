require 'spec_helper'

describe Discover do

  describe "#isUpperBusinessType?" do
    specify { Discover.new(businessType: 'soleTrader').isUpperBusinessType? == true }
    specify { Discover.new(businessType: 'partnership').isUpperBusinessType? == true }
    specify { Discover.new(businessType: 'limitedCompany').isUpperBusinessType? == true }
    specify { Discover.new(businessType: 'publicBody').isUpperBusinessType? == true }

    specify { Discover.new(businessType: 'charity').isUpperBusinessType? == false }
    specify { Discover.new(businessType: 'collectionAuthority').isUpperBusinessType? == false }
    specify { Discover.new(businessType: 'disposalAuthority').isUpperBusinessType? == false }
    specify { Discover.new(businessType: 'regulationAuthority').isUpperBusinessType? == false }
    specify { Discover.new(businessType: 'other').isUpperBusinessType? == false }

    specify { Discover.new(businessType: '').isUpperBusinessType? == false }
    specify { Discover.new(businessType: nil).isUpperBusinessType? == false }
  end

  describe "#is_upper?" do

  end
end