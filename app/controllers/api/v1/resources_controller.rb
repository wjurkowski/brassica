# FIXME extend ActionController::Metal instead as some mixins are not needed
class Api::V1::ResourcesController < ApplicationController
  include Pagination

  before_filter :authenticate_api_key!
  before_filter :require_allowed_model

  # FIXME find a way to document api calls

  def index
    filter_params = params[model_name.singularize].presence

    resources = filter_params ? model_klass.filter(filter_params) : model_klass.all
    resources = paginate_collection(resources)
    resources = decorate_collection(resources)

    render json: { model_name => resources, :meta => resources.meta }
  end

  def show
    resource = model_klass.find(params[:id])
    render json: decorate(resource)
  end

  private

  def authenticate_api_key!
    token = ApiKey.normalize_token(params[:api_key])
    unless token.present? && ApiKey.exists?(token: params[:api_key])
      render text: "Not Found", status: 404
    end
  end

  def require_allowed_model
    unless allowed_models.include?(model_name)
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def model_name
    @model_name ||= request.path.match(/\A\/api\/v1\/(([\w_]+)\/?)/)[2]
  end

  def model_klass
    @model_klass ||= model_name.classify.constantize
  end

  def allowed_models
    Brassica::Api.models.map { |klass| klass.name.underscore.pluralize }
  end

  def decorate_collection(resources)
    Api::CollectionDecorator.decorate(resources || [])
  end

  def decorate(resource)
    Api::Decorator.decorate(resource)
  end

end