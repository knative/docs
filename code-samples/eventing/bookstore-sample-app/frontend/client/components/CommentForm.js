'use-client';
import { useState } from 'react';
const CommentForm = () => {
	const [hover, setHover] = useState(false);
	const [comment, setComment] = useState('');

	const handleInputChange = (event) => {
		setComment(event.target.value);
	};

	const handleSubmit = (event) => {
		event.preventDefault();
		// Send the comment request as cloudevent to the review service
		fetch( "http://localhost:8080/add", {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				'Ce-Type': 'new-review-comment', // Assuming CloudEvents standard
				'Ce-Specversion': '1.0',
				'Ce-Source': 'commentForm',
				'Ce-Id': 'unique-comment-id'
			},
			body: JSON.stringify({
				input: comment
			})
		})
			.then(response => response.json())
			.then(data => {
				console.log('Success:', data);
				setComment(''); // Clear comment field after submission
			})
			.catch((error) => {
				console.error('Error:', error);
			});

	};
	return (
		<div className='flex my-4 p-4 justify-center'>
			<form
				className='w-full w-8/12 flex flex-col items-end '
				onSubmit={handleSubmit}
			>
				<textarea
					className='form-textarea w-full mb-2 p-2 border border-2 border-black rounded-lg p-4'
					rows='3'
					placeholder='Leave your comment here...'
					value={comment}
					onChange={handleInputChange}
				></textarea>
				<button
					type='submit'
					className={`font-bold py-2 px-9 rounded ${
						hover ? '' : 'bg-blue-600'
					}`}
					style={{ backgroundColor: hover ? '#A0DDFF' : '#A5D8FF' }}
					onMouseEnter={() => setHover(true)}
					onMouseLeave={() => setHover(false)}
				>
					Submit
				</button>
			</form>
		</div>
	);
};

export default CommentForm;
