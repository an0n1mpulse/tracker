# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chapter, type: :model do
  before :each do
    @org1 = create :organization
    @org2 = create :organization
    @chapter1 = create :chapter, chapter_name: 'Existing Chapter Spec Chapter', organization: @org1
  end

  describe 'is valid' do
    it 'with a valid, unique name in an organization' do
      chapter = Chapter.new chapter_name: 'Totally valid chapter', organization: @org1
      expect(chapter).to be_valid
      expect(chapter.chapter_name).to eql 'Totally valid chapter'
    end

    it 'with a duplicated name in different organization' do
      chapter = Chapter.new(
        chapter_name: 'Existing Chapter Spec Chapter',
        organization_id: @org2.id
      )
      expect(chapter).to be_valid
    end
  end

  describe 'is not valid' do
    it 'without chapter name' do
      chapter = Chapter.new chapter_name: nil
      expect(chapter).to_not be_valid
    end

    it 'with a nonexisting organization id' do
      chapter = Chapter.new chapter_name: 'Valid Name', organization_id: '1092837465'
      expect(chapter).to_not be_valid
    end

    it 'with a duplicated name in the same organization' do
      chapter = Chapter.new chapter_name: 'Existing Chapter Spec Chapter', organization_id: @org1.id
      expect(chapter).to_not be_valid
    end
  end

  describe 'scopes' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @chapter1 = create :chapter, organization: @org1
      @chapter2 = create :chapter, organization: @org1
      @chapter3 = create :chapter, organization: @org2
    end

    describe 'by_organization' do
      it 'should return only chapters belonging to a certain organization' do
        expect(Chapter.by_organization(@org1.id).length).to eq 2
        expect(Chapter.by_organization(@org1.id)).to include @chapter1, @chapter2
      end
    end
  end
end
