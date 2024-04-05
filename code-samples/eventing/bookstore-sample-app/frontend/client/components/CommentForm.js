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
		console.log('Submitted comment:', comment); // Use inspect to see
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
