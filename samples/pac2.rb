=begin
  pac2.rb - rcairo sample script with #scale and #translate.

  Original: pac.rb in http://www.artima.com/rubycs/articles/pdf_writer3.html
=end

$LOAD_PATH.unshift "../packages/cairo/ext/"
$LOAD_PATH.unshift "../packages/cairo/lib/"

require "cairo"

def pac(surface, width, height)
  white = [1, 1, 1]
  black = [0, 0, 0]
  magenta = [1, 0, 1]
  cyan = [0, 1, 1]
  yellow = [1, 1, 0]
  blue = [0, 0, 1]
  
  cr = Cairo::Context.new(surface)

  # NOTE: You may need to set line width when use Cairo::Context#scale
  cr.set_line_width(cr.line_width / [width, height].max)
  
  cr.scale(width, height)

  cr.save do
    cr.set_source_rgb(*black)
    cr.rectangle(0, 0, 1, 1)
    cr.fill
  end

  # Wall
  wall_width = 0.89
  wall_height = 0.03
  wall_space = 0.5
  wall_x = 0.02
  wall1_y = 1 - 0.86
  wall2_y = wall1_y + wall_space
  wall_radius = 0.01
  
  cr.set_source_rgb(*magenta)
  cr.rounded_rectangle(wall_x, wall1_y, wall_width, wall_height, wall_radius)
  cr.fill
  cr.set_source_rgb(*cyan)
  cr.rounded_rectangle(wall_x, wall1_y, wall_width, wall_height, wall_radius)
  cr.stroke
  
  cr.set_source_rgb(*magenta)
  cr.rounded_rectangle(wall_x, wall2_y, wall_width, wall_height, wall_radius)
  cr.fill
  cr.set_source_rgb(*cyan)
  cr.rounded_rectangle(wall_x, wall2_y, wall_width, wall_height, wall_radius)
  cr.stroke
  
  # Body
  body_x = 0.17
  body_y = 1 - 0.58
  body_width = 0.23
  body_height = 0.33
  
  cr.save do
    cr.translate(body_x, body_y)
    cr.set_source_rgb(*yellow)
    cr.scale(body_width, body_height)
    cr.arc(0, 0, 0.5, 30 * (Math::PI / 180), 330 * (Math::PI / 180))
    cr.line_to(0, 0)
    cr.close_path
    cr.fill
  end

  # Dot
  dot_width = 0.02
  dot_height = 0.03
  small_dot_width = 0.01
  small_dot_height = 0.015
  dot_x = 0.29
  dot_y = 1 - 0.58
  dot_step = 0.05
  
  cr.save do
    cr.set_source_rgb(*yellow)
    cr.save do
      cr.translate(dot_x, dot_y)
      cr.scale(dot_width, dot_height)
      cr.circle(0, 0, 1).fill
    end

    4.times do |i|
      cr.save do
        cr.translate(dot_x + dot_step * (i + 1), dot_y)
        cr.scale(small_dot_width, small_dot_height)
        cr.circle(0, 0, 1).fill
      end
    end
   end

  # Ghost
  ghost_x = 0.59
  ghost_x_step = 0.03
  ghost_y = 1 - 0.42
  ghost_y_step = 0.04
  ghost_width = 0.18
  ghost_height = 0.29
  ghost_radius= 0.08
  cr.move_to(ghost_x, ghost_y)
  cr.line_to(ghost_x, ghost_y - ghost_height)
  cr.curve_to(ghost_x + ghost_width / 3.0,
              ghost_y - ghost_height - ghost_radius,
              ghost_x + ghost_width * (2.0 / 3.0),
              ghost_y - ghost_height - ghost_radius,
              ghost_x + ghost_width,
              ghost_y - ghost_height)
  cr.line_to(ghost_x + ghost_width, ghost_y)
  i = 0
  (ghost_x + ghost_width).step(ghost_x, -ghost_x_step) do |x|
    cr.line_to(x, ghost_y + -ghost_y_step * (i % 2))
    i += 1
  end
  cr.close_path
  
  cr.set_source_rgb(*blue)
  cr.fill_preserve
  cr.set_source_rgb(*cyan)
  cr.stroke

  # Ghost Eyes
  eye_x = 0.62
  eye_y = 1 - 0.63
  eye_space = 0.06
  white_eye_width = 0.03
  white_eye_height = 0.04
  black_eye_width = 0.01
  black_eye_height = 0.02

  cr.set_source_rgb(*white)
  cr.rectangle(eye_x, eye_y - white_eye_height,
               white_eye_width, white_eye_height)
  cr.fill
  cr.rectangle(eye_x + eye_space, eye_y - white_eye_height,
               white_eye_width, white_eye_height)
  cr.fill
  
  cr.set_source_rgb(*black)
  cr.rectangle(eye_x, eye_y - black_eye_height,
               black_eye_width, black_eye_height)
  cr.fill
  cr.rectangle(eye_x + eye_space, eye_y - black_eye_height,
               black_eye_width, black_eye_height)
  cr.fill

  cr.show_page
end

width = 841.889763779528
height = 595.275590551181

surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32, width, height)
cr = pac(surface, width, height)
cr.target.write_to_png("pac2.png")

surface = Cairo::PSSurface.new("pac2.ps", width, height)
cr = pac(surface, width, height)
cr.target.finish

surface = Cairo::PDFSurface.new("pac2.pdf", width, height)
cr = pac(surface, width, height)
cr.target.finish
