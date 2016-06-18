class FramePresenter < Keynote::Presenter

  presents :frame

  def summary
    build_html do
      [frame.roll_1, frame.roll_2, frame.roll_3]
        .reject(&:blank?)
        .each_with_index do |number, i|
        span(class: "label #{label_color(number, frame, i)}") do
          strong(label_str(number, frame, i))
        end
        span(){' '}
      end
    end
  end

  private

  def label_color(number, frame, i)
    return 'label-danger' if show_as_strike?(number, frame, i)
    return 'label-warning' if show_as_spare?(frame, i)
    return 'label-default' if number.zero?
    'label-primary'
  end

  def label_str(number, frame, i)
    return 'X' if show_as_strike?(number, frame, i)
    return '/' if show_as_spare?(frame, i)
    return '-' if number.zero?
    number
  end

  def show_as_strike?(number, frame, i)
    if frame.last_frame?
      number == 10
    else
      frame.strike? && i == 0
    end
  end

  def show_as_spare?(frame, i)
    frame.spare? && (i == 1)
  end
end
