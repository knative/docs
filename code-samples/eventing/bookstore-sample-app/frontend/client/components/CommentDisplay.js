const CommentDisplay = ({ comment }) => {
	// Assume receiving a comment object
	return (
		<div className='flex my-4 p-4 justify-center align-middle items-center'>
			<div className='comment-display w-full w-7/12 flex flex-row rounded-lg p-4 bg-gray-800 text-white dark:bg-white dark:text-black'>
				<div className='flex items-center justify-center md:w-1/12'>
					<img
						src={comment.avatar}
						alt='Avatar'
						className='rounded-full w-8 h-8'
					/>
				</div>
				<div className='md:w-1/12 text-sm text-gray-200 dark:text-black'>
					{' '}
					{comment.time}{' '}
				</div>
				<div className='md:w-8/12'> {comment.text} </div>
				<div className='md:w-2/12'> {comment.emotion} </div>
			</div>
		</div>
	);
};

export default CommentDisplay;
