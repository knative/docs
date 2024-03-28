'use client';
import Header from '../components/Header';
import BookDetail from '../components/BookDetail';
import CommentForm from '../components/CommentForm';
import CommentList from '../components/CommentList';
import { ThemeProvider } from 'next-themes';

export default function Main() {
	/* Example Book object */
	const book = {
		title: 'Book Mock Up',
		author: 'me',
		ISBN: '12342432',
		publisher: 'dsfa',
		publishedDate: '3333',
		description: 'You are my fire! Hello world Im a book',
		price: '$10',
	};
	return (
		<div>
			<ThemeProvider attribute='class'>
				<Header />

				<main className='container mx-auto my-8'>
					<BookDetail book={book} />
					<CommentForm />
					<CommentList />
				</main>
			</ThemeProvider>
		</div>
	);
}
