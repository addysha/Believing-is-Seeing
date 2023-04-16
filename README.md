# Believing-is-Seeing
 Use Generative AI Art to produce a pair of pictures: one that historically could have occurred, and the other that could not have
The new online game that's sweeping the world: you get shown two photos, both of them generated using Generative AI Art, however one of them is plausibly correct, and the other is not. A photo of Charles Darwin using an early form of telephone. A photo of Alexander Graham Bell reading a copy of Winnie-the-Pooh. But which is correct?
I like the idea for this game, and would definitely be interested to play it. But how to go about producing a software environment that enables you to create such content for the game? This is the crux of the issue, for this project, in being able to develop such a game. But just to be clear, having a running version of the game that people can play is part of it.

The direction I would take is to produce a visualisation tool that allows you to plot interesting artefacts on a timeline. These artefacts could be, for instance, well known historical figures, inventions, or events. In the case of historical figures, the timeline would chart when they were born, and when they died, using date information sourced from Wikipedia, say. Similarly inventions and events could be plotted on the timeline, although they would typically be a single point representing when they occurred. To produce a picture that could be potentially true, select two artefacts that overlap, and use that information to ask a Generative AI Art programme to generate a picture. To produce a false picture, select two artefacts that don't overlap.

Some details to consider include: how far apart (or the extent of the overlap), which can be linked to the level of difficulty in determining if a photo is plausible or not; and to factor in where a person was known to have travelled to, as it could be that even though they were alive at the right time, the fact that they never travelled to where the (for instance) event took place, means in reality it could not have happened after all.

Taking the information from the visualiser, some manual experimentation with an Generative AI Art program would then be undertaken to generate the image use, which would then be followed by a simple mechanism to download it so it can be incorporated into the game. Say 5 rounds of two photos to a game with a high score table? (Note: I plucked the 5 pretty much from out of the air!). See The Infinite Jigsaw above for links to example Generative AI Art websites, if you're not already familiar with these sorts of sites.

In thinking of users playing the game, back in the photo creation phase you might like to vary the photos produced through rendering types such as photo (e.g., black and white for historic people) and painting (e.g., oil painting when going further back), even vary the artists painting style. When the user sees the photo, there is scope of a bit of game play development: do they see a text caption beneath the image straight from the start? Or perhaps for a small loss of points, they can ask for a hint, which reveals the text. Maybe even going one further and revealing the text that was entered to generate the photo (which could potentially give away a bit more information as to why the image composition was set the way it was).

In any event, when the user makes their guess—right or wrong—the program then reveals some text that explains which one is correct, and why, and why the other one is wrong.

Rather than resorting to page-scraping content from Wikipedia, a more machine readable form of content can be accessed via Linked data representations of Wikipedia, via DBpedia and/or WikiData.

Linked Data Resources:

An example based introduction to linked data
VizQuery has neat example of retrieving of pictures by self-portraits by Van Gogh at the VG Museum in Amsterdam
DataViz demonstrates how to take the linked data retrieved and transform it into a visualisation.
See WikiData for a fuller list of visualisation tools.
Don't for get to look at the photos of cats sample query accessible through the base WikiData query page.
Linked Jazz
