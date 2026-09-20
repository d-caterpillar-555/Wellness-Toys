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
    # Clip one: the kiss, whole and as the models came. It is the one that is
    # kept - the takes that followed it (the hold from behind, the lifted hold)
    # were removed, so this is the figure in both worlds.
    kiss: { shot: "kiss", count: 2000, width: 500, height: 625 }
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
