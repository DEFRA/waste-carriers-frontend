require 'spec_helper'

describe ConvictionSearchResult do

  describe '.search_person_convictions' do
    context 'valid params for person' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs', dateOfBirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'valid params for person (no DOB)' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs') }.not_to raise_error
      end
    end

    context 'params for company' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions(companyName: 'Acme Ltd.', companyNumber: '99999999') }.to raise_error
      end
    end

    context 'mix of params for person and company' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', companyNumber: '99999999') }.to raise_error
      end
    end

    context 'invalid params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', not_a_param: 'ABC') }.to raise_error
      end
    end

    context 'empty params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions({}) }.to raise_error
      end
    end

    describe 'error handling' do
      context 'services unavailable' do
        before { stub_request(:any, Rails.configuration.waste_exemplar_convictions_service_url).to_raise(Errno::ECONNREFUSED) }
        it 'should return a result flagged as an error' do
          skip 'Cannot get WebMock & VCR to behave as intended' # TODO: Make this test work with WebMock + VCR
          result = ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs')
          expect(result.match_result).to eq('UNKNOWN')
          expect(result.matching_system).to start_with('SERVICE_UNAVAILABLE')
        end
      end

      context 'server error' do
        before { stub_request(:any, Rails.configuration.waste_exemplar_convictions_service_url).to_raise }
        it 'should return a result flagged as an error' do
          skip 'Cannot get WebMock & VCR to behave as intended' # TODO: Make this test work with WebMock + VCR
          result = ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs')
          expect(result.match_result).to eq('UNKNOWN')
          expect(result.matching_system).to start_with('ERROR')
        end
      end
    end
  end


  describe '.search_company_convictions' do
    context 'valid params for company' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.', companyNumber: '99999999') }.not_to raise_error
      end
    end

    context 'valid params for person (no company number)' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.') }.not_to raise_error
      end
    end

    context 'params for person' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions(firstname: 'Fred', lastname: 'Blogs') }.to raise_error
      end
    end

    context 'mix of params for person and company' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.', firstname: 'Fred') }.to raise_error
      end
    end

    context 'invalid params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.', not_a_param: 'ABC') }.to raise_error
      end
    end

    context 'empty params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions({}) }.to raise_error
      end
    end

    describe 'error handling' do
      context 'timeout' do
        before { stub_request(:any, Rails.configuration.waste_exemplar_convictions_service_url).to_raise(Errno::ECONNREFUSED) }
        it 'should return a result flagged as an error' do
          skip 'Cannot get WebMock & VCR to behave as intended' # TODO: Make this test work with WebMock + VCR
          result = ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.', companyNumber: '99999999')
          expect(result.match_result).to eq('UNKNOWN')
          expect(result.matching_system).to start_with('SERVICE_UNAVAILABLE')
        end
      end

      context 'server error' do
        before { stub_request(:any, Rails.configuration.waste_exemplar_convictions_service_url).to_raise }
        it 'should return a result flagged as an error' do
          skip 'Cannot get WebMock & VCR to behave as intended' # TODO: Make this test work with WebMock + VCR
          result = ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.', companyNumber: '99999999')
          expect(result.match_result).to eq('UNKNOWN')
          expect(result.matching_system).to start_with('ERROR')
        end
      end
    end
  end

end
