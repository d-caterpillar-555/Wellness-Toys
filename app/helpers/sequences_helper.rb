module SequencesHelper
  # Rendered frame sequences: a study is drawn in Blender, rendered as one
  # transparent frame per step, and scrubbed by the reader's progress through a
  # world's page. Two worlds use them - figure, whose whole page is the study,
  # and folio, where one hangs as a plate in the document.
  #
  # They live in public/ because there are thousands of frames and nothing
  # gains from fingerprinting thousands of files. The folder name is the cache
  # key: a sequence is rendered into a new folder rather than over an old one,
  # so a reader who has seen the previous frames is never served them again.
  SEQUENCES = {
    # clip_1: the kiss, whole and as the models came, build and all - the pair
    # stand apart, meet, and stand apart again. The figure world scrubs this one
    # and keeps it.
    clip_1: { shot: "clip-1", count: 2000, width: 500, height: 625 },
    # film_1: one shot, joined. clip_1 is the kiss as it came, link_1 is his
    # arms coming up to take her waist - the animation's own move, walked
    # backwards, so it bends the way arms bend - and clip_2 is the kiss with his
    # hands brought down onto her seat, the solve fading in so they travel there
    # rather than starting there. The folio prints the whole thing as one
    # sequence: one layer, one count, and no fade between acts.
    film_1: { shot: "film-1", count: 3809, width: 500, height: 625 }
  }.freeze

  def sequence(name)
    SEQUENCES.fetch(name)
  end

  def sequence_base_path(name)
    "/worlds/figure/sequences/#{sequence(name)[:shot]}"
  end

  def sequence_path(name, number)
    format("%s/frame_%04d.webp", sequence_base_path(name), number)
  end
end
