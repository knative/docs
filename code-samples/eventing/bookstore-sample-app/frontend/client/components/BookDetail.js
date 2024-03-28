const BookDetail = ({ book }) => {
	// Assume receiving a book object
	return (
		<div className='flex flex-col md:flex-row md:items-start p-8 space-x-8 justify-center items-center font-sans'>
			<div className='mb-4 md:mb-0 md:mr-8'>
				<img
					src='/images/Bookcover.png'
					alt='Book Cover'
					className='w-48 h-auto'
				/>
			</div>
			<div>
				<div className='space-y-4'>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-3'>Title:</span>
						<span className='text-left'>{book.title}</span>
					</div>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-4'>Author:</span>
						<span className='text-left'>{book.author}</span>
					</div>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-4'>ISBN:</span>
						<span>{book.ISBN}</span>
					</div>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-4'>Publisher:</span>
						<span>{book.publisher}</span>
					</div>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-4'>Published Date:</span>
						<span>{book.publishedDate}</span>
					</div>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-4'>Description:</span>
						<span>{book.description}</span>
					</div>
					<div className='grid grid-cols-2 items-center'>
						<span className='font-bold text-left pr-4'>Price:</span>
						<span>{book.price}</span>
					</div>
				</div>
			</div>
		</div>
	);
};

export default BookDetail;
