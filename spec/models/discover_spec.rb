require 'spec_helper'

describe Discover do

  describe "#upper_business_type?" do
    specify { Discover.new(businessType: 'soleTrader').upper_business_type? == true }
    specify { Discover.new(businessType: 'partnership').upper_business_type? == true }
    specify { Discover.new(businessType: 'limitedCompany').upper_business_type? == true }
    specify { Discover.new(businessType: 'publicBody').upper_business_type? == true }

    specify { Discover.new(businessType: 'charity').upper_business_type? == false }
    specify { Discover.new(businessType: 'collectionAuthority').upper_business_type? == false }
    specify { Discover.new(businessType: 'disposalAuthority').upper_business_type? == false }
    specify { Discover.new(businessType: 'regulationAuthority').upper_business_type? == false }
    specify { Discover.new(businessType: 'other').upper_business_type? == false }

    specify { Discover.new(businessType: '').upper_business_type? == false }
    specify { Discover.new(businessType: nil).upper_business_type? == false }
  end

  describe "#is_upper?" do

  end
end