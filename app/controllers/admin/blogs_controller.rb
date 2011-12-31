#encoding: utf-8
class Admin::BlogsController < Admin::AppController
  prepend_before_filter :authenticate_user!
  layout 'admin'

  expose(:blogs){ current_user.shop.blogs}
  expose(:blog)
  expose(:articles){
    if params[:search]
      blog.articles.metasearch(params[:search]).all
    else
      blog.articles
    end
  }
  expose(:status) { KeyValues::PublishState.hash }
  expose(:commentable_types){ KeyValues::CommentableType.options}
  expose(:authors){
    blog.articles.select(:author).map(&:author).uniq
  }
  expose(:tags){
    blog.articles.map(&:tags).flatten.map(&:name).uniq
  }

  def create
    if blog.save
      redirect_to blog_path(blog), notice: "新增成功!"
    else
      render action:'new'
    end
  end

  def update
    if blog.save
      flash[:notice] = I18n.t("flash.actions.#{action_name}.notice")
      redirect_to blog_path(blog)
    else
      render action:'edit'
    end
  end

  def destroy
    blog.destroy
    flash[:notice] = I18n.t("flash.actions.#{action_name}.notice")
    respond_to do |format|
      format.js { render template: "admin/pages/destroy" }
    end
  end
end
