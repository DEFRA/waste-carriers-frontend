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

    context 'error handling' do
      # Note: We *don't* have a VCR tag on this test, so VCR won't know how to
      # handle the request to the convictions service, and will return its own
      # error text from the REST call.  This gives an unconventional but
      # acceptable way to simulate error conditions.
      it 'should return a result flagged as an error' do
        skip 'Cannot get WebMock & VCR to behave as intended' # TODO: Make this test work with WebMock + VCR
        result = ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs')
        expect(result.match_result).to eq('UNKNOWN')
        expect(result.matching_system).to start_with('ERROR')
      end
    end

    context 'search with last and first name' do
      it 'matches on last and first when possible', :vcr do
        result = ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs')
        expect(result.match_result).to eq('YES')
        expect(result.matching_system).to eq('ABC')
        expect(result.reference).to eq('1234')
        expect(result.get_formatted_reference).to eq('ABC-1234')
        expect(result.matched_name).to eq('Blogs, Fred')
      end

      it 'matches on last name only when required', :vcr do
        result = ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Smith')
        expect(result.match_result).to eq('YES')
        expect(result.reference).to eq('A4567')
      end

      it 'doesnt match when it shouldnt', :vcr do
        result = ConvictionSearchResult.search_person_convictions(firstname: 'Billy', lastname: 'Bluehat')
        expect(result.match_result).to eq('NO')
      end

      it 'will match part of a hypenated surname', :vcr do
        result = ConvictionSearchResult.search_person_convictions(firstname: 'Roger', lastname: 'Brown')
        expect(result.match_result).to eq('YES')
        expect(result.matching_system).to eq('CDE')
        expect(result.reference).to eq('3456')
      end
    end

    context 'search with last name only' do
      it 'will match when it should', :vcr do
        result = ConvictionSearchResult.search_person_convictions(lastname: 'Brown')
        expect(result.match_result).to eq('YES')
      end

      it 'will match even when multiple possibilities', :vcr do
        result = ConvictionSearchResult.search_person_convictions(lastname: 'Blogs')
        expect(result.match_result).to eq('YES')
      end

      it 'doesnt match when it shouldnt', :vcr do
        result = ConvictionSearchResult.search_person_convictions(lastname: 'Bluehat')
        expect(result.match_result).to eq('NO')
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

    context 'error handling' do
      # Note: We *don't* have a VCR tag on this test, so VCR won't know how to
      # handle the request to the convictions service, and will return its own
      # error text from the REST call.  This gives an unconventional but
      # acceptable way to simulate error conditions.
      it 'should return a result flagged as an error' do
        skip 'Cannot get WebMock & VCR to behave as intended' # TODO: Make this test work with WebMock + VCR
        result = ConvictionSearchResult.search_company_convictions(companyName: 'Acme Ltd.', companyNumber: '99999999')
        expect(result.match_result).to eq('UNKNOWN')
        expect(result.matching_system).to start_with('SERVICE_UNAVAILABLE')
      end
    end

    context 'search with company number' do
      it 'will match on company number when possible', :vcr do
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '12345678', companyName: 'Wrong company name')
        expect(result.match_result).to eq('YES')
        expect(result.matching_system).to eq('PQR')
        expect(result.reference).to eq('7766')
        expect(result.get_formatted_reference).to eq('PQR-7766')
        expect(result.matched_name).to eq('Test Waste Services Ltd.')
      end

      it 'will match company number with leading zeros 1', :vcr do
        # Convictions CSV database omits the leadings zeros in company number,
        # but client keeps leading zeros.
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '00654321', companyName: 'Wrong company name')
        expect(result.match_result).to eq('YES')
        expect(result.reference).to eq('Z-4321-01')
      end

      it 'will match company number with leading zeros 2', :vcr do
        # Convictions CSV database and client keep leading zeros.
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '00009876', companyName: 'Wrong company name')
        expect(result.match_result).to eq('YES')
        expect(result.matched_name).to eq('Recycle-pro (UK) Limited')
      end

      it 'doesnt match when it shouldnt', :vcr do
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '99999999', companyName: 'Wrong company name')
        expect(result.match_result).to eq('NO')
      end
    end

    context 'search with company name' do
      it 'will find an exact match', :vcr do
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '99999999', companyName: 'Test Waste Services Ltd.')
        expect(result.match_result).to eq('YES')
        expect(result.get_formatted_reference).to eq('PQR-7766')
      end

      it 'will find a word match ignoring puctuation', :vcr do
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '99999999', companyName: 'Recycle pro UK Limited')
        expect(result.match_result).to eq('YES')
        expect(result.matched_name).to eq('Recycle-pro (UK) Limited')
      end

      it 'will find a match ignoring common terms', :vcr do
        result = ConvictionSearchResult.search_company_convictions(companyNumber: '99999999', companyName: 'Recycle-pro')
        expect(result.match_result).to eq('YES')
        expect(result.matched_name).to eq('Recycle-pro (UK) Limited')
      end
    end
  end

end
