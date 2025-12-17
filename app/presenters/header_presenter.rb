class HeaderPresenter
  attr_reader :title, :subtitle, :show_back_button, :show_new_deck_button, :show_profile_menu,
    :back_path, :right_buttons

  def initialize(view_context, options = {})
    @view                 = view_context
    @back_path            = options[:back_path]
    @title                = options[:title]
    @subtitle             = options[:subtitle]
    @show_back_button     = options[:show_back_button] || false
    @show_new_deck_button = options[:show_new_deck_button] || false
    @show_profile_menu    = options.fetch(:show_profile_menu, true)
    @right_buttons        = options[:right_buttons]
  end

  def render
    @view.render partial: "shared/header", locals: locals
  end

  def locals
    {
      back_path: back_path,
      title: title,
      subtitle: subtitle,
      show_back_button: show_back_button,
      show_new_deck_button: show_new_deck_button,
      show_profile_menu: show_profile_menu,
      right_buttons: right_buttons
    }
  end
end
