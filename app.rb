require 'sinatra'

ARR_PHIE = %w(0 1 2 3 4 5 6 7 8 9 ¯ - « ⅄ Ⅺ ⸘ ‽ ¿ ? ! * + e b d u i k Q E w h c m n o p C r L t Y l v s y & K O A % N Z H T J a _ I B U F G z V R $ M P f S W D D g / ~ \\ ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ~ ­ . | ,) << " " #<< ":"
ARR_WOTC = %w(0 1 2 3 4 5 6 7 8 9 − - « Y X ⸘ ‽ ¿ ? ! * + a b d e f g h i j k l m n o p q r s t u v w x y z ð ø č ķ ŋ θ ţ ť ž ǆ ǥ ǧ ǩ ɒ ə ɢ ɣ ɬ ɮ ɴ ʁ π φ χ ẅ ’ ' š : " / -0 -1 -2 -3 -4 -5 -6 -7 -8 -9 +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 " “ . ^) << " " << "," #<< " "
ARR_WOTC_GSUB_FROM_START = %w(¿ “ ‽ ⸘ ? ! " ^ «)
ARR_WOTC_GSUB_FROM_END = %w(: - “ « . ^)

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

  post '/remapper/v1' do
    @text = from_unicode(from_base64_to(params[:t])) || ""
    @direction = CGI.unescape(params[:d] || "")

    remapped = ""

    if @direction.to_s == "normal"
      arr_from = ARR_WOTC
      arr_to = ARR_PHIE
      direction = "gibberish"
      invert_direction = "normal"
    else
      arr_from = ARR_PHIE
      arr_to = ARR_WOTC
      direction = "normal"
      invert_direction = "gibberish"
    end

    @text.chars.each do |char|
      if char == "\n"
        remapped += "\n"
      elsif direction == "normal"
        if ARR_PHIE.include? char
          i = arr_from.find_index(char)
          remapped += i.nil? ? char : arr_to[i]
        elsif char == "\n"
          remapped += "\n"
        end
      elsif direction == "gibberish"
        if ARR_WOTC.include? char
          i = arr_from.find_index(char)
          remapped += i.nil? ? char : arr_to[i]
        elsif char == "\n"
          remapped += "\n"
        end
      end
    end

    space_gsubber = ->(x){x == "^" ? "\\^" : x}

    ARR_WOTC_GSUB_FROM_END.each do |gg|
      remapped.gsub!(/[#{space_gsubber.call(gg)}](\s|[,])/, "#{gg} ")
    end

    ARR_WOTC_GSUB_FROM_START.each do |gg|
      remapped.gsub!(/(\s|[,])[#{space_gsubber.call(gg)}]/, " #{gg}")
    end

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