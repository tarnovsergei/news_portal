# coding: UTF-8
# DOC:
# We use Helper Methods for tree building,
# because it's faster than View Templates and Partials

# SECURITY note
# Prepare your data on server side for rendering
# or use h.html_escape(node.content)
# for escape potentially dangerous content
module RenderCommentsTreeHelper
  module Render 
    class << self
      attr_accessor :h, :options
      Time::DATE_FORMATS[:ru_datetime] = "%d %B in %k:%M"

      # Main Helpers
      def controller
        @options[:controller]
      end

      def t str
        controller.t str
      end

      # Render Helpers
      def visible_draft?
        controller.try(:comments_view_token) == @comment.view_token
      end

      def moderator?
        controller.try(:current_user).try(:comments_moderator?, @comment)
      end

      # Render Methods
      def render_node(h, options)
        @h, @options = h, options
        @comment     = options[:node]

        @max_reply_depth = options[:max_reply_depth] || TheComments.config.max_reply_depth

        if @comment.draft?
          draft_comment
        else @comment.published?
          published_comment
        end
      end

      def draft_comment
        if visible_draft? || moderator?
          published_comment
        else
          "<li class='draft'>
            <div class='comment draft' id='comment_#{@comment.anchor}'>
              #{ t('the_comments.waiting_for_moderation') }
              #{ h.link_to '#', '#comment_' + @comment.anchor }
            </div>
            #{ children }
          </li>"
        end
      end

      def published_comment
        "<li>
          <div id='comment_#{@comment.anchor}' class='comment #{@comment.state}' data-comment-id='#{@comment.to_param}'>
            <div>
              #{ avatar }
              #{ userbar }
              <div class='cbody'>#{ @comment.content }</div>
              #{ reply }
            </div>
          </div>

          <div class='form_holder'></div>
          #{ children }
        </li>"
      end

      def avatar
        "<div class='userpic'>
          <img src='#{ @comment.avatar_url }' alt='userpic' />
          #{ controls }
        </div>"
      end

      def userbar
        #title  = @comment.title.blank? ? t('the_comments.guest_name') : @comment.title
        if @comment.user_id.blank?
          title = t('the_comments.guest_name')
        else
          title = User.find_by(id: @comment.user_id).username
        end
        time = @comment.created_at.to_s(:ru_datetime)
        "<div class='userbar'>#{ title } &nbsp &nbsp &nbsp &nbsp #{ time } </div>"
      end

      def moderator_controls
        if moderator?
          h.link_to(t('the_comments.edit'), h.edit_comment_url(@comment), class: :edit)
        end
      end

      def reply
        if @comment.depth < (@max_reply_depth - 1)
          "<p class='reply'><a href='#' class='reply_link'>#{ t('the_comments.reply') }</a>"
        end
      end

      def delete
        if controller.try(:user_signed_in?)
          if controller.try(:current_user).admin?
            h.link_to "Delete", @comment ,:confirm => 'Are you sure?', method: :delete, :remote => true, class: :edit
          end
        end
      end

      def controls
        #"<div class='controls'>#{ moderator_controls }</div>"
        "<div class='controls'>#{ delete }</div>"
      end

      def children
        "<ol class='nested_set'>#{ options[:children] }</ol>"
      end
    end
  end
end