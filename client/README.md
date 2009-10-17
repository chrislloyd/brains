## Notes

The tiling algorithm could use adaptive caching. There are two areas that need to be considered for speed. The initial display time and latency when moving the map around. The display time is bound by the amount of objects that have to be loaded into the DOM and rendered (even if they are off screen). The movement latency is influenced by the number of absolute positions that need to be modified each frame.

Strangely, when the images are floated left, this then means that each of their floats have to be re-calculated when the overall object is moved. It is much faster to have them display inline.

Currently, by loading the whole map then moving the container, the initial load time is slow but the movement time is fast. The other way of doing it would be to have every image absolutely positioned and then adjust the images' positions. This would mean that we only need to keep the currently displaying images in the DOM. Load time would be much faster, but movement time would be far slower (as 100's of nodes would have to be updated and redrawn).

I believe a hybrid solution is needed to solve the performance problem. Tiles should be loaded in to containers (the size of which are set based on the screen width). This means that only the tiles needed to be displayed are loaded (and therefore loading is fast). When moving the map, the number of DOM updates is minimised.

... Loading in new elements loads in new absolutely positioned elements until they can be placed in a container.

