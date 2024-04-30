import Emoji from './Emoji';
const CommentDisplay = ({ comment }) => {
	// Assume receiving a comment object
	let emoji;
	if (comment.emotion === 'Positive') {
		emoji = '😃';
	} else if (comment.emotion === 'Neutral') {
		emoji = '😐';
	} else {
		emoji = '😡';
	}
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
				<div className='md:w-1/12 flex items-center content-center text-gray-200 dark:text-black'>
					{comment.time}
				</div>
				<div className='md:w-9/12 '>
					<span className='h-full flex items-center content-center'>
						{comment.text}
					</span>
				</div>
				<div className='md:w-1/12 text-4xl flex items-center content-center'>
					<Emoji symbol={emoji} label={comment.emotion} size='text-2xl' />
				</div>
			</div>
		</div>
	);
};

export default CommentDisplay;
