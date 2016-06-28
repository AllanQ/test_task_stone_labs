require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'validations' do
    it { should belong_to(:question) }
    it { should belong_to(:user) }
    it { should validate_presence_of(:question) }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:text) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:question_id)
      .with_message("user can't have more than one answer to one question") }
  end

end
