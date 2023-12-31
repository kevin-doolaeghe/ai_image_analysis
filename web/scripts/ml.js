function imageToTensor(data, width, height) {
    const buffer = new Uint8Array(width * height * 3)
    let offset = 0;
    for (let i = 0; i < buffer.length; i += 3) {
        buffer[i] = data[offset];
        buffer[i + 1] = data[offset + 1];
        buffer[i + 2] = data[offset + 2];
        offset += 4;
    }

    return tf.tensor3d(buffer, [height, width, 3]);
}

async function classifyImage(data, width, height) {
    let result = [];
    try {
        let tensor = imageToTensor(data, width, height);

        // Load the MobileNet model
        const model = await mobilenet.load();

        // Classify the image
        let predictions = await model.classify(tensor);

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

    let result = [];
    return result;
}
