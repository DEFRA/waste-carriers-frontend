require 'spec_helper'

describe Discover do

  it { should allow_value('soleTrader', 'partnership', 'limitedCompany', 'publicBody', 'charity', 'collectionAuthority', 'disposalAuthority', 'regulationAuthority').for(:businessType) }
  it { should_not allow_value('ltd', 'plc', 'other').for(:businessType) }

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

    specify { Discover.new(businessType: nil, otherBusinesses: nil, constructionWaste: nil, isMainService: nil, onlyAMF: nil).should_not be_upper_tier }

    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'yes').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', isMainService: 'no', constructionWaste: 'yes').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', isMainService: 'yes', onlyAMF: 'no').should be_upper_tier }

    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'no', isMainService: 'no', onlyAMF: 'no').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'no', isMainService: 'no', onlyAMF: 'yes').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'no', isMainService: 'yes', onlyAMF: 'no').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'no', isMainService: 'yes', onlyAMF: 'no').should_not be_upper_tier }

    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'yes', isMainService: 'no', onlyAMF: 'no').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'yes', isMainService: 'no', onlyAMF: 'yes').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'yes', isMainService: 'yes', onlyAMF: 'no').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'no', constructionWaste: 'yes', isMainService: 'yes', onlyAMF: 'no').should be_upper_tier }

    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'no', isMainService: 'no', onlyAMF: 'no').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'no', isMainService: 'no', onlyAMF: 'yes').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'no', isMainService: 'yes', onlyAMF: 'yes').should_not be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'no', isMainService: 'yes', onlyAMF: 'yes').should_not be_upper_tier }

    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'yes', isMainService: 'no', onlyAMF: 'no').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'yes', isMainService: 'no', onlyAMF: 'yes').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'yes', isMainService: 'yes', onlyAMF: 'no').should be_upper_tier }
    specify { Discover.new(businessType: 'soleTrader', otherBusinesses: 'yes', constructionWaste: 'yes', isMainService: 'yes', onlyAMF: 'yes').should_not be_upper_tier }
  end

  describe "#validate_businessType" do
    context "empty" do
      subject { Discover.new(businessType: '') }

      before do
        subject.validate_businessType
      end

      it "errors" do
        subject.errors[:businessType].should include 'must be completed'
      end
    end

    context "other" do
      subject { Discover.new(businessType: 'other') }

      before do
        subject.validate_businessType
      end

      it "errors" do
        subject.errors[:businessType].should include 'has an invalid selection'
      end
    end

    context "soleTrader" do
      subject { Discover.new(businessType: 'soleTrader') }

      before do
        subject.validate_businessType
      end

      it "doesn't error" do
        subject.errors[:businessType].should be_empty
      end
    end
  end
end