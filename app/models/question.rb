class Question < ActiveRecord::Base
  belongs_to :question_category
  has_many   :answers, dependent: :destroy
  has_many   :users, through: :answers

  validates_associated :answers
  validates :question_category_id, :text, presence: true
  validates :text, uniqueness: true, length: { minimum: 3 }

  scope :joins_answers, -> (user_id, is_answered) {
    select('ARRAY_AGG(answers.id) AS answer_id, questions.*')
    .joins("LEFT JOIN answers\
 ON answers.question_id = questions.id AND answers.user_id = #{user_id}")
    .where("answers.id IS#{is_answered ? ' NOT ' : ' '}NULL")
    .group('questions.id')
  }
  scope :joins_answers_from_category, -> (user_id, is_answered, category_id) {
    joins_answers(user_id, is_answered)
    .where("question_category_id = #{category_id}")
  }
  scope :previous_questions, -> (id) { where("questions.id < #{id}")
                                      .order('questions.id') }
  scope :next_questions,     -> (id) { where("questions.id > #{id}")
                                      .order('questions.id') }

  def self.scope_questions(type_questions = 'All questions', user_id,
                           category_id)
    res = Question.where(question_category_id: category_id) if
      type_questions == 'All questions'
    res = Question.joins_answers_from_category(user_id, true, category_id) if
      type_questions == 'Questions with answers'
    res = Question.joins_answers_from_category(user_id, false, category_id) if
      type_questions == 'Questions without answers'
    res
  end


  # SELECT SUBSTRING(question_categories.ancestry FROM '\d+$') AS parent_id FROM question_categories;
  #
  #
  #
  # with recursive tree (name, id, level, pathstr) as (select name, id, 0, cast('' as text) from question_categories where parent_id is null union all select question_categories.name, question_categories.id, tree.level + 1, tree.pathstr || CAST(question_categories.name AS TEXT) from question_categories inner join tree on tree.id = question_categories.parent_id) select id, (level || ' ' || name) as name from tree order by pathstr;
  #
  # with recursive tree (name, id, level, pathstr) as (select name, id, 0, cast('' as text) from question_categories where CAST(SUBSTRING(question_categories.ancestry FROM '\d+$') AS INTEGER) is null union all select question_categories.name, question_categories.id, tree.level + 1, tree.pathstr || CAST(question_categories.name AS TEXT) from question_categories inner join tree on tree.id = CAST(SUBSTRING(question_categories.ancestry FROM '\d+$') AS INTEGER)) select id, (level || ' ' || name) as name from tree order by pathstr;
  #
  #
  #
  #
  #
  # WITH RECURSIVE tree AS ( SELECT id, name, parent_id, CAST(id as text) AS sort_string, 1 AS depth FROM question_categories WHERE parent_id IS NULL UNION ALL SELECT s1.id, s1.name, s1.parent_id, tree.sort_string || '|' || s1.id AS sort_string, tree.depth+1 AS depth FROM tree JOIN question_categories s1 ON s1.parent_id = tree.id ) SELECT depth, name, id, parent_id, sort_string FROM tree ORDER BY sort_string ASC;
  #
  # WITH RECURSIVE tree AS ( SELECT id, name, ancestry, CAST(id as text) AS sort_string, 1 AS depth FROM question_categories WHERE ancestry IS NULL UNION ALL SELECT s1.id, s1.name, s1.ancestry, tree.sort_string || '|' || s1.id AS sort_string, tree.depth+1 AS depth FROM tree JOIN question_categories s1 ON CAST(SUBSTRING(s1.ancestry FROM '\d+$') AS INTEGER) = tree.id ) SELECT depth, name, id, ancestry, sort_string FROM tree ORDER BY sort_string ASC;
  #
  #
  #
  # SELECT *, concat(ancestry || '/', id) AS sort_string FROM question_categories ORDER BY sort_string ASC;
  #
  # QuestionCategory.select("*, concat(ancestry || '/', id) AS sort_string").order('sort_string')
  #
  #
  # SELECT concat(question_categories.ancestry || '/', question_categories.id) AS sort_string, * FROM questions LEFT OUTER JOIN question_categories ON questions.question_category_id = question_categories.id ORDER BY sort_string ASC;
  #
  # SELECT concat(question_categories.ancestry || '/', question_categories.id) AS sort_string, questions.id, questions.text FROM questions LEFT OUTER JOIN question_categories ON questions.question_category_id = question_categories.id ORDER BY sort_string, id ASC;
  #
  #
  #
  #
  # SELECT questions.id, questions.text FROM (WITH RECURSIVE tree AS ( SELECT id, name, parent_id, CAST(id as text) AS sort_string, 1 AS depth FROM question_categories WHERE parent_id IS NULL UNION ALL SELECT s1.id, s1.name, s1.parent_id, tree.sort_string || '|' || s1.id AS sort_string, tree.depth+1 AS depth FROM tree JOIN question_categories s1 ON s1.parent_id = tree.id ) SELECT depth, name, id, parent_id, sort_string FROM tree) AS categories RIGHT OUTER JOIN questions ON questions.question_category_id = categories.id ORDER BY sort_string, questions.id ASC;
  #




  # SELECT concat(question_categories.ancestry || '/', question_categories.id)
  #          AS sort_string,
  #        questions.id, questions.text
  #   FROM questions LEFT OUTER JOIN question_categories
  #   ON questions.question_category_id = question_categories.id
  #   ORDER BY sort_string, questions.id ASC;
  #
  # Question.select("concat(question_categories.ancestry || '/', question_categories.id) AS sort_string, questions.id, questions.text").joins('LEFT OUTER JOIN question_categories ON questions.question_category_id = question_categories.id').order('sort_string, questions.id')
  #
  #
  #
  # SELECT questions.id, questions.text
  #   FROM questions
  #   LEFT OUTER JOIN (
  #     WITH RECURSIVE tree AS (
  #                              SELECT id, name, parent_id, CAST(id as text) AS sort_string, 1 AS depth
  #     FROM question_categories
  #     WHERE parent_id IS NULL
  #
  #     UNION ALL
  #
  #     SELECT s1.id, s1.name, s1.parent_id,
  #            tree.sort_string || '|' || s1.id AS sort_string,
  #                                                tree.depth+1 AS depth
  #     FROM tree
  #     JOIN question_categories s1
  #     ON s1.parent_id = tree.id
  #     )
  #     SELECT depth, name, id, parent_id, sort_string FROM tree
  #   ) AS categories
  #   ON questions.question_category_id = categories.id
  # ORDER BY sort_string, questions.id ASC;
  #
  # Question.select('questions.id, questions.text').joins("LEFT OUTER JOIN ( WITH RECURSIVE tree AS ( SELECT id, name, parent_id, CAST(id as text) AS sort_string, 1 AS depth FROM question_categories WHERE parent_id IS NULL UNION ALL SELECT s1.id, s1.name, s1.parent_id, tree.sort_string || '|' || s1.id AS sort_string, tree.depth+1 AS depth FROM tree JOIN question_categories s1 ON s1.parent_id = tree.id ) SELECT depth, name, id, parent_id, sort_string FROM tree ) AS categories ON questions.question_category_id = categories.id").order('sort_string, questions.id')


  def previous_question(type_questions, user_id)
    res = previous_question_in_category(type_questions, user_id, id,
                                        question_category_id)
    return res if res
    array_category_sorted           = QuestionCategory.sort_by_ancestry
    index_category_current_question = array_category_sorted
      .index(QuestionCategory.find(question_category_id))
    array_category_sorted[0..(index_category_current_question - 1)].reverse
      .map do |category|
      res = previous_question_in_category(type_questions, user_id, id,
                                          category.id)
      return res if res
    end
    res
  end

  def previous_question_in_category(type_questions, user_id, question_id,
                                    question_category_id)
    case type_questions
    when 'All questions'
      Question.where(question_category_id: question_category_id)
              .previous_questions(question_id)
              .last
    when 'Questions with answers'
      Question.joins_answers_from_category(user_id, true, question_category_id)
              .previous_questions(question_id)
              .last
    when 'Questions without answers'
      Question.joins_answers_from_category(user_id, false, question_category_id)
              .previous_questions(question_id)
              .last
    end
  end

  def next_question(type_questions, user_id)
    res = previous_question_in_category(type_questions, user_id, id,
                                        question_category_id)
    return res if res
    array_category_sorted           = QuestionCategory.sort_by_ancestry
    index_category_current_question = array_category_sorted
      .index(QuestionCategory.find(question_category_id))
    array_category_sorted[(index_category_current_question + 1)..-1]
      .map do |category|
      res = previous_question_in_category(type_questions, user_id, id,
                                          category.id)
      return res if res
    end
    res
  end

  def next_question_in_category(type_questions, user_id, question_id,
                                    question_category_id)
    case type_questions
      when 'All questions'
        Question.where(question_category_id: question_category_id)
          .next_questions(question_id)
          .first
      when 'Questions with answers'
        Question.joins_answers_from_category(user_id, true, question_category_id)
          .next_questions(question_id)
          .first
      when 'Questions without answers'
        Question.joins_answers_from_category(user_id, false, question_category_id)
          .next_questions(question_id)
          .first
    end
  end
end
