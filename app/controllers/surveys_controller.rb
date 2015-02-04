class SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_active_top_nav_link_to_surveys
  before_action :authenticate_research




  def index

  end

  def show


    @survey = Survey.find_by_slug(params["slug"])
    @answer_session = AnswerSession.find_or_create(current_user, @survey)

    survey_layout
  end



  def show_report
    @survey = Survey.find_by_slug(params["slug"])
    @answer_session = AnswerSession.find_or_create(current_user, @survey)

    render "show_report-new", layout: 'layouts/cleantheme' if current_user.beta_opt_in?
  end

  def process_answer
    @questions = Question.where(id: params[:question_id])
    @answer_session = AnswerSession.find(params[:answer_session_id]) # Validate user!

    @questions.each do |question|
      @answer = @answer_session.process_answer(question, params)
    end

    respond_to do |format|
      format.html do
        if @answer_session.completed?
          redirect_to survey_report_path(@answer_session)
        else
          redirect_to ask_question_path(question_id: @answer.next_question.id, answer_session_id: @answer_session.id)
        end
      end
      format.json { render json: {answer: @answer, value: @answer.string_value, errors: @answer.errors.full_messages } }
    end

  end

  ## Deprecated


  def start_survey
    survey = Survey.find(params[:survey_id])
    answer_session =  AnswerSession.current.find_by(user_id: current_user.id, survey_id: survey.id)

    if answer_session
      # Do not restart a survey
      redirect_to surveys_path
    else
      answer_session = AnswerSession.create(user_id: current_user.id, survey_id: survey.id)
      redirect_to ask_question_path(question_id: survey.first_question_id, answer_session_id: answer_session.id)
    end
  end

  def intro
    @survey = Survey.find(params[:survey_id])
  end


  def ask_question
    @answer_session = AnswerSession.find(params[:answer_session_id])
    @question = Question.find(params[:question_id])

    if @question.part_of_group?
      @group = @question.group
      @questions = @group.minimum_set(@answer_session.survey)
      @answer = Answer.current.where(question_id: @questions.first.id, answer_session_id: @answer_session.id).first || Answer.new(question_id: @questions.first.id, answer_session_id: @answer_session.id)
    else
      @answer = Answer.current.where(question_id: @question.id, answer_session_id: @answer_session.id).first || Answer.new(question_id: @question.id, answer_session_id: @answer_session.id)
    end
  end


  private

  def survey_layout
    if current_user.beta_opt_in?
      render layout: 'layouts/cleantheme'

    else
      render layout: 'main'
    end
  end

end
