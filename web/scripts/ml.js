function imageToTensor(data, width, height) {
    // Drop the alpha channel info for mobilenet
    const buffer = new Uint8Array(width * height * 3);
    let offset = 0;
    for (let i = 0; i < buffer.length; i += 3) {
        buffer[i] = data[offset];
        buffer[i + 1] = data[offset + 1];
        buffer[i + 2] = data[offset + 2];
        offset += 4;
    }
    return tf.tensor3d(buffer, [height, width, 3]);
}

async function classifyImage(image) {
    let result = [];

    try {
        // Convert the image
        let tensorImage = tf.tensor3d(image.data, [image.height, image.width, 3]);

        // Load the MobileNet model
        const version = 2;
        const alpha = 0.5;
        const model = await mobilenet.load({ version, alpha });

        // Classify the image
        let predictions = await model.classify(tensorImage);
        console.log(predictions);

        // Extract the result
        predictions.forEach((item, _) => result.push(`${item.className} (${item.probability * 100} %)`));
    } catch (error) {
        console.log('Error: ' + error);
    }

    result = result.join(' - ');
    return result.toString();
}

async function detectObjects(image) {
    let result = [];

    try {
        // Convert the image
        let tensorImage = tf.tensor3d(image.data, [image.height, image.width, 3]);

        // Load the COCO-SSD model
        const model = await cocoSsd.load();

        // Detect the object on image
        let predictions = await model.detect(image);
        console.log(predictions);

        // Extract the result
        predictions.forEach((item, _) => result.push(item.class));
    } catch (error) {
        console.log('Error: ' + error);
    }

    result = result.join(' - ');
    return image.data;
}
