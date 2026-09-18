# The visual worlds, in the order the switch presents them.
#
# One list, read by the layout (which resolves the world before first paint and
# must reject a value it does not know) and by the switch itself. The controller
# reads the rendered buttons, so nothing else can drift.
STYLE_WORLDS = %w[tidewater solarium studio herbarium].freeze
