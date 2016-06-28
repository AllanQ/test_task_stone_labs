require 'rails_helper'
require_relative '../../config/initializers/rails_admin'

describe 'rails_admin configuration' do
  let(:category1) { create(:question_category, name: 'First') }
  let(:category2) { create(:question_category, name: 'Second',
                           ancestry: "#{category1.id}") }
  let(:category3) { create(:question_category, name: 'Third',
                           ancestry: "#{category1.id}/#{category2.id}") }
  it 'return full name of the category' do
    expect(full_path(category3, true)).to eq('First -> Second -> Third')
    expect(full_path(category1, true)).to eq('First')
  end
  it 'return full path to the category' do
    expect(full_path(category3, false)).to eq('First -> Second')
    expect(full_path(category1, false)).to eq(nil)
  end
end
