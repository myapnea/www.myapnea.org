# frozen_string_literal: true

# Allows survey builders to add answer templates to survey questions.
class Builder::AnswerTemplatesController < Builder::BuilderController
  before_action :authenticate_user!
  before_action :redirect_non_builders
  before_action :find_editable_survey_or_redirect
  before_action :find_editable_question_or_redirect
  before_action :find_editable_answer_template_or_redirect, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to builder_survey_question_path(@survey, @question)
  end

  def new
    @answer_template = @question.answer_templates.new
  end

  def create
    @answer_template = @question.answer_templates.where(user_id: current_user.id).new(answer_template_params)
    if @answer_template.save
      @question.answer_templates_questions.create(answer_template_id: @answer_template.id, position: @question.max_position + 1)
      redirect_to builder_survey_question_answer_template_path(@survey, @question, @answer_template), notice: 'Answer Template was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @answer_template.update(answer_template_params)
      redirect_to builder_survey_question_answer_template_path(@survey, @question, @answer_template), notice: 'Answer Template was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @answer_template.destroy
    redirect_to builder_survey_question_path(@survey, @question), notice: 'Answer Template was successfully destroyed.'
  end

  # POST /answer_templates/reorder.js
  def reorder
    params[:answer_template_ids].each_with_index do |answer_template_id, index|
      atq = @question.answer_templates_questions.find_by answer_template_id: answer_template_id
      atq.update position: index if atq
    end
    head :ok
  end

  private

  def find_editable_answer_template_or_redirect
    super(:id)
  end

  def answer_template_params
    params.require(:answer_template).permit(
      :name, :template_name, :parent_answer_template_id,
      :parent_answer_option_value, :text, :unit, :archived
    )
  end
end
