require 'sinatra'

ARR_GIBBERISH = %w(       0 1 2 3 4 5 6 7 8 9 ¯ - « ⅄ Ⅺ ⸘ ‽ ¿ ? ! * + e b d u i k Q E w h c m n o p C r L t Y l v s y & K O A % N Z H T J a _ I B U F G z V R $ M P f S W D D g / \\ ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ : ~ ­ . | ,) << " "
ARR_NORMAL = %w(       0 1 2 3 4 5 6 7 8 9 − - « Y X ⸘ ‽ ¿ ? ! * + a b d e f g h i j k l m n o p q r s t u v w x y z ð ø č ķ ŋ θ ţ ť ž ǆ ǥ ǧ ǩ ɒ ə ɢ ɣ ɬ ɮ ɴ ʁ π φ χ ẅ ’ ' š : / -0 -1 -2 -3 -4 -5 -6 -7 -8 -9 +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 , " “ . ^) << " " << ","
ARR_NORMAL_GSUB_FROM_START = %w(¿ “ ‽ ⸘ ? ! " ^ «)
ARR_NORMAL_GSUB_FROM_END = %w(: - “ « . ^)

PHIE_ALIAS = "gibbersih"
WOTC_ALIAS = "normal"

configure {
  set :server, :puma
}

class Remapper < Sinatra::Base

  get '/' do
    erb :index
  end

  post '/check' do
    content_type :json
    { something: "#{params[:t]}" }.to_json
  end

  post '/remapper/v2' do

    @text = params[:t] || ""
    @direction_from = params[:d] || ""

    remapped = ""

    if @direction_from.to_s == "normal"
      arr_from = ARR_NORMAL
      arr_to = ARR_GIBBERISH
      direction_gibberish_to_normal = false
    else
      arr_from = ARR_GIBBERISH
      arr_to = ARR_NORMAL
      direction_gibberish_to_normal = true
    end

    remap = lambda do |char|
      i = arr_from.find_index(char)
      remapped += i.nil? ? char : arr_to[i]
    end

    @text.chars.each do |char|
      if char == "\n"
        remapped += "\r\n"
      elsif direction_gibberish_to_normal && ARR_GIBBERISH.include?(char) || !direction_gibberish_to_normal && ARR_NORMAL.include?(char)
        remap.call(char)
      end
    end

    space_gsubber = Proc.new{ |x| x == "^" ? "\\^" : x }

    ARR_NORMAL_GSUB_FROM_END.each do |char|
      remapped.gsub!(/[#{space_gsubber.call(char)}](\s|[,])/, "#{char} ")
    end

    ARR_NORMAL_GSUB_FROM_START.each do |char|
      remapped.gsub!(/(\s|[,])[#{space_gsubber.call(char)}]/, " #{char}")
    end

    remapped.gsub!(/(^(\s|[,])*|(\s|[,])*$)/, "")
    remapped_line_start_fix = direction_gibberish_to_normal ? /[\\.]\s{2,}[\|]/ : /[\\.]\s{2,}[\^]/
    remapped.gsub!(remapped_line_start_fix , ".\r\n|")

    remapped_array = []
    remapped.each_char do |char|
      remapped_array << to_unicode(char)
    end

    content_type :json
    {direction: direction_gibberish_to_normal ? "gibberish" : "normal", invert_direction: direction_gibberish_to_normal ? "normal" : "gibberish", text: remapped_array}.to_json

  end

  post '/remapper/v1' do
    @text = from_unicode(from_base64_to(params[:t])) || ""
    @direction = CGI.unescape(params[:d] || "")

    remapped = ""

    if @direction.to_s == "normal"
      arr_from = ARR_NORMAL
      arr_to = ARR_GIBBERISH
      direction = "gibberish"
      invert_direction = "normal"
    else
      arr_from = ARR_GIBBERISH
      arr_to = ARR_NORMAL
      direction = "normal"
      invert_direction = "gibberish"
    end

    @text.chars.each do |char|
      if char == "\n"
        remapped += "\r\n"
      elsif direction == "normal" && ARR_GIBBERISH.include?(char)
        i = arr_from.find_index(char)
        remapped += i.nil? ? char : arr_to[i]
      elsif direction == "gibberish" && ARR_NORMAL.include?(char)
        i = arr_from.find_index(char)
        remapped += i.nil? ? char : arr_to[i]
      end
    end

    space_gsubber = ->(x){x == "^" ? "\\^" : x}

    ARR_NORMAL_GSUB_FROM_END.each do |gg|
      remapped.gsub!(/[#{space_gsubber.call(gg)}](\s|[,])/, "#{gg} ")
    end

    ARR_NORMAL_GSUB_FROM_START.each do |gg|
      remapped.gsub!(/(\s|[,])[#{space_gsubber.call(gg)}]/, " #{gg}")
    end

    remapped.gsub!(/(^(\s|[,])*|(\s|[,])*$)/, "")
    remapped.gsub!(/[\\.]\s{2,}[\|]/, ".\r\n|")
    remapped.gsub!(/[\\.]\s{2,}[\^]/, ".\r\n^")

    remapped_array = []
    remapped.each_char do |char|
      remapped_array << to_unicode(char)
    end

    content_type :json
    {direction: direction.to_s, invert_direction: invert_direction.to_s, text: remapped_array}.to_json

  end

  run! if app_file == $0

  private

  def to_base64(string)
    require 'base64'
    Base64.encode64(string)
  end

  def from_base64_to(string)
    require 'base64'
    Base64.decode64(string)
  end

  def to_unicode(string)
    string.to_s.unpack('U*').map { |i| i.to_s(16).rjust(4, '0') }.join.to_i(16)
  end

  def from_unicode(array)
    array.split(",").reject(&:empty?).map(&:to_i).pack('U*').to_s
  end
end