RailsAdmin.config do |config|
  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)
  ## == Cancan ==
  config.authorize_with :cancan, AdminAbility

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    bulk_delete
    edit
    delete
  end

  config.model 'Answer' do
    list do
      field :question_category do
        formatted_value do
          question_id = bindings[:object].question_id
          question_category_id = Question.find(question_id).question_category_id
          QuestionCategory.find(question_category_id).name
        end
      end
      field :question
      field :user
      field :text do
        label 'Answer'
      end
    end
  end

  config.model 'Question' do
    object_label_method do
      :custom_label_method_text
    end
    list do
      field :path do
        formatted_value do
          question = bindings[:object]
          category = QuestionCategory.find(question.question_category_id)
          full_path(category, true)
        end
      end
      field :text
    end
    edit do
      exclude_fields :answers, :users
    end
  end

  config.model 'QuestionCategory' do
    list do
      field :path do
        formatted_value do
          category = bindings[:object]
          full_path(category, false)
        end
      end
      field :name
    end
    edit do
      field :name
      field :parent_id, :enum do
        enum_method do
          :parent_enum
        end
      end
    end
  end

  config.model 'User' do
    list do
      field :name
      field :email
      field :user_status
      field :admin
      field :activated
      field :answered_questions do
        formatted_value do
          user_id = bindings[:object].id
          Answer.where(user_id: user_id).count
        end
      end
    end
    edit do
      exclude_fields :admin, :answers, :questions, :reset_password_sent_at
    end
  end

  config.model 'UserStatus' do
    list do
      field :name
    end
    edit do
      field :name
    end
  end

  def custom_label_method_text
    self.text
  end

  def full_path(category, with_name)
    if category.ancestors.length > 0
      res = ( category.ancestors.inject('') { |str, anc_category|
        "#{str} -> #{anc_category.name}" } )[3..-1]
      res = "#{res} -> #{category.name}" if with_name
    else
      res = category.name if with_name
    end
    res
  end
end
