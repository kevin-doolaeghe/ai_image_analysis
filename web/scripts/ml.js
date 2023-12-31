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
    console.log(image);
    let tensorImage = imageToTensor(image.data, image.width, image.height);
    try {
        // Load the MobileNet model
        const model = await mobilenet.load();

        // Classify the image
        let predictions = await model.classify(tensorImage);

        // Extract the result
        predictions.forEach((item, _) => result.push(item));
    } catch (error) {
        console.log('Error: ' + error);
    }

    console.log(result);
    return result.toString();
}

async function detectObjects(image) {
    // TODO: add detectObjects method
    return image.data;
}
