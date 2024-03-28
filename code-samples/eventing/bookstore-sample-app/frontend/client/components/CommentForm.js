import SubmitButton from './SubmitButton';
const CommentForm = () => {
	return (
		<div className='flex my-4 p-4 justify-center'>
			<form className='w-full w-8/12 flex flex-col items-end'>
				<textarea
					className='form-textarea w-full mb-2 p-2 border border-2 border-black rounded-lg p-4'
					rows='3'
					placeholder='Leave your comment here...'
				></textarea>
				<SubmitButton />
			</form>
		</div>
	);
};

export default CommentForm;
