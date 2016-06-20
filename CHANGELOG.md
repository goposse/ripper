
# Changelog

## 0.7.1

- Adds and `imageCacheMode` property to `Ripper` instances to allow you to store either processed images or the originals. Default is `.Processed`.

## 0.7

- Fixes an issue with cell reuse and image operation cancellation
- Tidys up the operation queue (more robust, less cross class communication)
- Fixes some bugs in finalization of the queue

## 0.5.1

- **BREAKING**: Renamed `.resize()` to `.resizeFilter()` to better indicate it's global nature and set up the upcoming filter framework
- Fixed issues with scaling of images
- Code tidying

## 0.5

- Initial public release
