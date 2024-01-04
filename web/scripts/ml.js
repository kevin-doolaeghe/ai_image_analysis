async function classifyImage(image) {
    try {
        // Convert the image
        const tensorImage = tf.tensor3d(image.data, [image.height, image.width, 3]);

        // Load the MobileNet model
        const model = await mobilenet.load();

        // Classify the image
        const predictions = await model.classify(tensorImage);
        console.log(predictions);

        // Extract the results
        let results = predictions.map((x) => ({
            item: x.className,
            probability: x.probability,
        }));
        return results;
    } catch (error) {
        console.log(`Error: ${error}`);
        return [];
    }
}

async function detectObjects(image) {
    try {
        // Convert the image
        const tensorImage = tf.tensor3d(image.data, [image.height, image.width, 3]);

        // Load the COCO-SSD model
        const model = await cocoSsd.load();

        // Detect the object on image
        const predictions = await model.detect(tensorImage);
        console.log(predictions);

        // Extract the results
        let results = predictions.map((x) => ({
            item: x.class,
            probability: x.score,
            coords: x.bbox,
        }));
        return results;
    } catch (error) {
        console.log(`Error: ${error}`);
        return [];
    }
}
