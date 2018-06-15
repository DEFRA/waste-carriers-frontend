require 'spec_helper'

describe ConvictionSearchResult do

  describe '.search_person_convictions' do
    context 'valid params for person' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs', dateofbirth: '1970-01-01') }.not_to raise_error
      end
    end

    context 'valid params for person (no DOB)' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs') }.not_to raise_error
      end
    end

    context 'params for company' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions(name: 'Acme Ltd.', number: '99999999') }.to raise_error(ArgumentError)
      end
    end

    context 'mix of params for person and company' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', number: '99999999') }.to raise_error(ArgumentError)
      end
    end

    context 'invalid params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions(firstname: 'Fred', not_a_param: 'ABC') }.to raise_error(ArgumentError)
      end
    end

    context 'empty params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_person_convictions({}) }.to raise_error(RuntimeError)
      end
    end

    context 'error handling' do
      # Note: We *don't* have a VCR tag on this test, so VCR won't know how to
      # handle the request to the convictions service, and will return its own
      # error text from the REST call.  This gives an unconventional but
      # acceptable way to simulate error conditions.
      it 'should return a result flagged as an error' do
        result = ConvictionSearchResult.search_person_convictions(firstname: 'Fred', lastname: 'Blogs')
        expect(result.match_result).to eq('UNKNOWN')
        expect(result.matching_system).to start_with('ERROR')
        expect(result.reference).to be_blank
        expect(result.matched_name).to be_blank
        expect(result.confirmed).to eq('no')
      end
    end
  end

  describe '.search_company_convictions' do
    context 'valid params for company' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_company_convictions(name: 'Acme Ltd.', number: '99999999') }.not_to raise_error
      end
    end

    context 'valid params for person (no company number)' do
      it 'does not error' do
        expect { ConvictionSearchResult.search_company_convictions(name: 'Acme Ltd.') }.not_to raise_error
      end
    end

    context 'params for person' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions(firstname: 'Fred', lastname: 'Blogs') }.to raise_error(ArgumentError)
      end
    end

    context 'mix of params for person and company' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions(name: 'Acme Ltd.', firstname: 'Fred') }.to raise_error(ArgumentError)
      end
    end

    context 'invalid params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions(name: 'Acme Ltd.', not_a_param: 'ABC') }.to raise_error(ArgumentError)
      end
    end

    context 'empty params' do
      it 'errors' do
        expect { ConvictionSearchResult.search_company_convictions({}) }.to raise_error(RuntimeError)
      end
    end

    context 'error handling' do
      # Note: We *don't* have a VCR tag on this test, so VCR won't know how to
      # handle the request to the convictions service, and will return its own
      # error text from the REST call.  This gives an unconventional but
      # acceptable way to simulate error conditions.
      it 'should return a result flagged as an error' do
        result = ConvictionSearchResult.search_company_convictions(name: 'Acme Ltd.', number: '99999999')
        expect(result.match_result).to eq('UNKNOWN')
        expect(result.matching_system).to start_with('ERROR')
        expect(result.reference).to be_blank
        expect(result.matched_name).to be_blank
        expect(result.confirmed).to eq('no')
      end

    end
  end
end
