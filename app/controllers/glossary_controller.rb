class GlossaryController < ApplicationController
  def index
    @terms = policy_scope(Article).glossary_terms.alphabetical
  end

  def show
    @term = policy_scope(Article).glossary_terms.with_evidence.find_by!(slug: params[:term])
    authorize @term
  end
end
