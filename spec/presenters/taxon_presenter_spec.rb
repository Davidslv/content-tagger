require 'rails_helper'

RSpec.describe TaxonPresenter do
  let(:taxon_form) do
    instance_double(TaxonForm, title: 'My Title', base_path: "/taxons/my-taxon")
  end
  let(:presenter) { TaxonPresenter.new(taxon_form) }

  describe "#payload" do
    let(:payload) { presenter.payload }

    it "generates a valid payload" do
      expect(payload).to be_valid_against_schema('taxon')
    end

    it 'assigns the expected rendering app' do
      expect(payload[:publishing_app]).to eq('content-tagger')
    end
  end
end
