require 'spec_helper'

describe Discover do

  describe "#upper_business_type?" do
    specify { Discover.new(businessType: 'soleTrader').should be_upper_business_type }
    specify { Discover.new(businessType: 'partnership').should be_upper_business_type }
    specify { Discover.new(businessType: 'limitedCompany').should be_upper_business_type }
    specify { Discover.new(businessType: 'publicBody').should be_upper_business_type }

    specify { Discover.new(businessType: 'charity').should_not be_upper_business_type }
    specify { Discover.new(businessType: 'collectionAuthority').should_not be_upper_business_type }
    specify { Discover.new(businessType: 'disposalAuthority').should_not be_upper_business_type }
    specify { Discover.new(businessType: 'regulationAuthority').should_not be_upper_business_type }
    specify { Discover.new(businessType: 'other').should_not be_upper_business_type }

    specify { Discover.new(businessType: '').should_not be_upper_business_type }
    specify { Discover.new(businessType: nil).should_not be_upper_business_type }
  end

  describe "#upper_tier?" do
    specify { Discover.new(businessType: 'charity').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'yes').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', isMainService: 'no', constructionWaste: 'yes').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', isMainService: 'yes', onlyAMF: 'no').should be_upper_tier }
  end
end