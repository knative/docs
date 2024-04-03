const BookDetail = ({ book }) => {
    return (
        <div className='flex flex-col md:flex-row md:items-start p-8 space-x-8 justify-center items-center font-sans'>
            <div className='mb-4 md:mb-0 md:mr-8'>
                <img src={book.img} alt='Book Cover' className='w-48 h-auto' />
            </div>
            <div>
                <div className='space-y-4'>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>Title:</span>
                        <span className='text-left'>{book.title}</span>
                    </div>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>Author:</span>
                        <span className='text-left'>{book.author}</span>
                    </div>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>ISBN:</span>
                        <span>{book.ISBN}</span>
                    </div>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>Publisher:</span>
                        <span>{book.publisher}</span>
                    </div>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>Published Date:</span>
                        <span>{book.publishedDate}</span>
                    </div>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>Description:</span>
                        <span>{book.description}</span>
                    </div>
                    <div className='grid grid-cols-[auto_1fr] gap-x-2 items-center'>
                        <span className='font-bold text-left'>Price:</span>
                        <span>{book.price}</span>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default BookDetail;
